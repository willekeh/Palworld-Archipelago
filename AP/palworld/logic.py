"""Parses the logic strings of the data files (locations, regions, events) and turns them into Archipelago rules.

Grammar: atoms joined by AND / OR, grouped with parentheses, AND binds tighter than OR.
Atoms:  (Item: Name)   (Item: Name : count)   (Can Access: Region)
        (Event: Name)  (Location: Name, true when that location is reachable)

This module imports nothing from Archipelago, so it can be tested on its own.
"""
import re

tokenPattern = re.compile(r"\((?:Can Access|Item|Event|Location): [^()]*\)|\(|\)|AND|OR")
atomPattern = re.compile(r"\((Can Access|Item|Event|Location): (.*)\)$")

constantTrue = ("const", True)  # logic without any condition


def parseLogic(logicText):
    leftoverText = tokenPattern.sub("", logicText).strip()
    if leftoverText:
        raise ValueError("unparsed text in logic: " + repr(leftoverText))
    tokens = tokenPattern.findall(logicText)
    if not tokens:
        return constantTrue
    tokenPosition = 0

    def peekToken():
        return tokens[tokenPosition] if tokenPosition < len(tokens) else None

    def parseOrExpression():
        nonlocal tokenPosition
        operands = [parseAndExpression()]
        while peekToken() == "OR":
            tokenPosition += 1
            operands.append(parseAndExpression())
        return operands[0] if len(operands) == 1 else ("or", tuple(operands))

    def parseAndExpression():
        nonlocal tokenPosition
        operands = [parsePrimary()]
        while peekToken() == "AND":
            tokenPosition += 1
            operands.append(parsePrimary())
        return operands[0] if len(operands) == 1 else ("and", tuple(operands))

    def parsePrimary():
        nonlocal tokenPosition
        token = peekToken()
        if token == "(":
            tokenPosition += 1
            innerExpression = parseOrExpression()
            if peekToken() != ")":
                raise ValueError("missing closing parenthesis in: " + logicText)
            tokenPosition += 1
            return innerExpression
        if token is None or token in (")", "AND", "OR"):
            raise ValueError("unexpected token " + repr(token) + " in: " + logicText)
        tokenPosition += 1
        atomMatch = atomPattern.match(token)
        return ("atom", atomMatch.group(1), atomMatch.group(2).strip())

    expression = parseOrExpression()
    if tokenPosition != len(tokens):
        raise ValueError("trailing tokens in: " + logicText)
    return expression


def toClauses(node):
    """Disjunctive normal form: a list of clauses, each clause a list of atoms that must all hold."""
    nodeKind = node[0]
    if nodeKind == "const":
        return [[]]
    if nodeKind == "atom":
        return [[node]]
    clauseListsOfChildren = [toClauses(childNode) for childNode in node[1]]
    if nodeKind == "or":
        return [clause for clauseList in clauseListsOfChildren for clause in clauseList]
    combinedClauses = [[]]
    for clauseList in clauseListsOfChildren:
        combinedClauses = [existingClause + newClause for existingClause in combinedClauses for newClause in clauseList]
    return combinedClauses


def compileNode(node, player):
    nodeKind = node[0]
    if nodeKind == "atom":
        atomKind, atomBody = node[1], node[2]
        if atomKind == "Item":
            bodyParts = atomBody.split(" : ")
            itemName = bodyParts[0].strip()
            requiredCount = int(bodyParts[1]) if len(bodyParts) > 1 else 1
            return lambda state: state.has(itemName, player, requiredCount)
        if atomKind == "Event":
            return lambda state: state.has(atomBody, player)
        if atomKind == "Location":
            return lambda state: state.can_reach(atomBody, "Location", player)
        regionName = atomBody  # (Can Access: Region), the only kind left
        return lambda state: state.can_reach(regionName, "Region", player)
    childRules = [compileNode(childNode, player) for childNode in node[1]]
    if nodeKind == "and":
        return lambda state: all(childRule(state) for childRule in childRules)
    return lambda state: any(childRule(state) for childRule in childRules)


def buildRule(logicText, player):
    """Rule for a location or the goal. Returns None when the logic is empty (always reachable)."""
    node = parseLogic(logicText)
    if node == constantTrue:
        return None
    return compileNode(node, player)


def buildEntrances(logicText, player):
    """Splits a region's logic into entrances.

    Each OR-branch that names exactly one region becomes an entrance from that region; a branch
    that names no region comes from the Menu. The branch's items become the entrance rule.
    Returns a list of (sourceRegionName, rule or None).
    """
    entrances = []
    for clause in toClauses(parseLogic(logicText)):
        regionAtoms = [atom for atom in clause if atom[1] == "Can Access"]
        otherAtoms = [atom for atom in clause if atom[1] != "Can Access"]
        if len(regionAtoms) > 1:
            raise NotImplementedError("a region needing several other regions at once: " + logicText)
        sourceRegionName = regionAtoms[0][2] if regionAtoms else "Menu"
        if otherAtoms:
            clauseRules = [compileNode(atom, player) for atom in otherAtoms]
            entranceRule = lambda state, rules=clauseRules: all(rule(state) for rule in rules)
        else:
            entranceRule = None
        entrances.append((sourceRegionName, entranceRule))
    return entrances

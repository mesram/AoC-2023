const workflows = {};
for await (const line of console) {
    if (line === "") break;
    const [, name, rawRules] = new RegExp("^([a-z]+){(.*)}$").exec(line);
    const rules = rawRules.split(",");
    const parsedRules = rules.map(rule => {
        const workflowMatch = new RegExp("([axms])([<>])(\\d+):(.*)").exec(rule);
        if (workflowMatch) {
            const [, property, comparison, amount, destination] = workflowMatch;
            return {
                property, 
                comparison, 
                amount: Number(amount), 
                destination,
            }
        } else {
            return rule
        }
    });

    workflows[name] = parsedRules;
}

let successfulRanges = [];
function test(workflow, ranges) {
    if (workflow === "A") {
        successfulRanges.push(ranges);
        return;
    }

    if (workflow === "R") { return; }

    for (const rule of workflows[workflow]) {
        if (typeof rule === "string") {
            test(rule, ranges);
        } else {
            const { 
                property,
                comparison,
                amount,
                destination,
            } = rule;

            const { min, max } = ranges[property];
            let testValue;
            if (comparison === "<") {
                testValue = { ...ranges, [property]: { min, max: amount - 1 }};
                ranges = { ...ranges, [property]: { min: amount, max }};
            } else {
                testValue = {...ranges, [property]: { min: amount + 1, max }};
                ranges = { ...ranges, [property]: { min, max: amount }}
            }

            test(destination, testValue);
        }
    }
}

test("in", {
    x: { min: 1, max: 4000 },
    m: { min: 1, max: 4000 },
    a: { min: 1, max: 4000 },
    s: { min: 1, max: 4000 },
})

let total = 0;
for (const range of successfulRanges) {
    const possibilities = 
        (range.x.max - range.x.min + 1) 
        * (range.m.max - range.m.min + 1) 
        * (range.a.max - range.a.min + 1) 
        * (range.s.max - range.s.min + 1)
    total += possibilities;
}

console.log(total);
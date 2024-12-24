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

const testRegex = new RegExp("{x=(\\d+),m=(\\d+),a=(\\d+),s=(\\d+)}");

let total = 0;
for await (const line of console) {
    const [, x, m, a, s] = line.match(testRegex).map(Number);

    if (test("in", {x, m, a, s})) total += x + m + a + s;
}

function test(workflow, value) {
    if (workflow === "A") {
        return true;
    }

    if (workflow === "R") { 
        return false; 
    }

    for (const rule of workflows[workflow]) {
        if (typeof rule === "string") {
            return test(rule, value);
        } else {
            const { 
                property,
                comparison,
                amount,
                destination,
            } = rule;

            const testValue = value[property];
            if (comparison === "<" && testValue < amount) {
                return test(destination, value);
            } else if (comparison === ">" && testValue > amount) {
                return test(destination, value);
            }
        }
    }
}

console.log(total);
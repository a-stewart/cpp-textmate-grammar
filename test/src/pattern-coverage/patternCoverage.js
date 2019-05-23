// stores coverage results for grammars
const jsonSourceMap = require("json-source-map");
const _ = require("lodash");

class patternCoverage {
    /**
     * @typedef {{source: string, count: number[], sumTime: number[]}} Coverage
     */
    constructor(grammar, scopeName) {
        // converts a grammar into a list of pointers which become an array of coverage objects
        const pointers = jsonSourceMap.parse(grammar).pointers;
        /**
         * @type {{[source: string]: Coverage}}
         */
        this.coverage = [];
        this.scopeName = scopeName;
        this.empty = true;
        for (const pointer of Object.keys(pointers)) {
            if (/(?:match|begin|end|while)$/.test(pointer)) {
                const source = scopeName + ":" + pointers[pointer].key.line;
                this.coverage[source] = {
                    source,
                    // order is failure, unchosen, chosen
                    count: [0, 0, 0],
                    sumTime: [0, 0, 0]
                };
            }
        }
    }
    record(source, time, chosen, failure, onlyPattern) {
        this.empty = false;
        const index = failure ? 0 : chosen ? 2 : 1;
        this.coverage[source].count[index] += 1;
        this.coverage[source].sumTime[index] += time;
        if (onlyPattern && chosen) {
            this.coverage[source].count[1] += 1;
            this.coverage[source].sumTime[1] += time;
        }
    }
    report() {
        let averages = [0, 0, 0];
        let notConsidered = 0;
        for (const coverage of Object.values(this.coverage)) {
            if (coverage.count[0] > 0) {
                averages[0] += 1;
            }
            // if the recorded pattern is the only pattern in the set, don't count matched unChosen against it
            if (coverage.count[1] > 0) {
                averages[1] += 1;
            }
            if (coverage.count[2] > 0) {
                averages[2] += 1;
            }
            if (_.every(coverage.count, v => v === 0)) {
                notConsidered += 1;
            }
        }
        const totalPatterns = Object.keys(this.coverage).length;
        averages[0] /= totalPatterns;
        averages[1] /= totalPatterns;
        averages[2] /= totalPatterns;
        console.log(
            "code coverage for %s:\n\t%f%% / %f%% / %f%% / %f%%\n\t(match failure / match not chosen / match chosen / average)",
            this.scopeName,
            (averages[0] * 100).toFixed(2),
            (averages[1] * 100).toFixed(2),
            (averages[2] * 100).toFixed(2),
            (_.mean(averages) * 100).toFixed(2)
        );
        console.log(
            "\t%d (%f%%) patterns were never considered",
            notConsidered,
            ((notConsidered / totalPatterns) * 100).toFixed(2)
        );
    }
    isEmpty() {
        return this.empty;
    }
}

let recorders = {};

module.exports = {
    loadRecorder: function(grammar, scopeName) {
        if (recorders[scopeName]) {
            return;
        }
        recorders[scopeName] = new patternCoverage(grammar, scopeName);
    },
    getRecorder: function(scopeName) {
        return recorders[scopeName];
    },
    reportAllRecorders: function() {
        for (const recorder of Object.values(recorders)) {
            if (!recorder.isEmpty()) {
                recorder.report();
            }
        }
    }
};

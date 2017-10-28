var _user$project$Native_Benchmark = (function () {
    function bench(name, fn) {
        return {
            name: name,
            fn: fn
        }
    }

    function suite(name, fnList) {
        var fns = _elm_lang$core$Native_List.toArray(fnList),
            suite = new Benchmark.Suite(name),
            i, curr;

        for (i = 0; i < fns.length; i++) {
            curr = fns[i];
            suite = suite.add(curr.name, curr.fn);
        }

        return suite;
    }

    function run(suiteList, program) {
        var suites = _elm_lang$core$Native_List.toArray(suiteList),
            i;

        for (i = 0; i < suites.length; i++) {
            suites[i].on('start', function () {
                console.log('Starting ' + this.name + ' suite.');
            }).on('cycle', function (event) {
                console.log(String(event.target));
            }).on('complete', function () {
                console.log('Done with ' + this.name + ' suite.');
            }).run();
        }

        return program;
    }

    return {
        bench: F2(bench),
        suite: F2(suite),
        run: F2(run)
    };
})()

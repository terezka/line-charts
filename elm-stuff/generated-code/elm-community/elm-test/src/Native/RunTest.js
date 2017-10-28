var _user$project$Native_RunTest = function()
{
    return {
      runThunk: function(thunk) {
        try {
          // Attempt to run the thunk as normal.
          return thunk({ctor: '_Tuple0'});

        } catch (err) {
          // If it throws, return a test failure instead of crashing.
          return {
            ctor: '::',
            _0: _elm_community$elm_test$Expect$fail(
              "This test failed because it threw an exception: \"" + err + "\""
            ),
            _1: {ctor: '[]'}
          };
        }
      }
    };
}();

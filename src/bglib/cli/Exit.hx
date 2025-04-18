package bglib.cli;

import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
import tink.core.Error;

/**
 * Exit handler for CLI applications.
**/
class Exit {
    /**
     * Handle result.
     * @param result of the operation.
    **/
    public static function handler(result:Outcome<Noise, Error>) {
        switch result {
            case Success(_):
            case Failure(e):
                var message = e.message;
                if (e.data != null) message += ', ${e.data}';
                Sys.println(message);
                Sys.exit(e.code);
        }
    }
}

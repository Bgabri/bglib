package bglib.cli;

import tink.core.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
class Exit {
    public static function handler(result:Outcome<Noise, Error>) {
        switch result {
            case Success(_):
                Sys.exit(0);
            case Failure(e):
                var message = e.message;
                if (e.data != null) message += ', ${e.data}';
                Sys.println(message);
                Sys.exit(e.code);
        }
    }
}
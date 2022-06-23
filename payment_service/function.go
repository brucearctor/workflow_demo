package function

import (
	"encoding/json"
	"fmt"

	"io/ioutil"
	"net/http"
	// would prefer that this be published elsewhere where installable.
	// for ease including it within this module.
	pw "examplepaymentservice.com/payment/mygreatexamplecompany.com/retailworkflow"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("ChargeCard", chargeCard)
}

// I wonder whether card should be charged before kickstarting the workflow! :-)
// oh, well, product determination -- I'll suggest/ask why we're not doing that.
func chargeCard(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)

	order := pw.Order{}
	err := json.Unmarshal([]byte(reqBody), &order)
	if err != nil {
		http.Error(w, "Bad Data ... UnMarshal Problem", http.StatusBadRequest)
	}

	// HIT A PAYMENT SERVICE ...
	// IN THE EVENT THAT WORKFLOWS WOULDN"T CONNECT IN PLACE OF THIS!

	u, err := json.Marshal(order)
	if err != nil {
		http.Error(w, "Bad Data ... Marshal Problem", http.StatusBadRequest)
	}

	fmt.Fprintln(w, string(u))
}

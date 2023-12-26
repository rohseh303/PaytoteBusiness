import express from 'express';
import fetch from 'node-fetch';
import 'dotenv/config';
const app = express();
app.use(express.json());
app.use(express.urlencoded({
    extended: true
}));
const port = process.env.PORT || 3000;
const environment = process.env.ENVIRONMENT || 'sandbox';
const client_id = process.env.CLIENT_ID;
const client_secret = process.env.CLIENT_SECRET;
const endpoint_url = environment === 'sandbox' ? 'https://api-m.sandbox.paypal.com' : 'https://api-m.paypal.com';

/**
 * Creates an order and returns it as a JSON response.
 * @function
 * @name createOrder
 * @memberof module:routes
 * @param {object} req - The HTTP request object.
 * @param {object} req.body - The request body containing the order information.
 * @param {string} req.body.intent - The intent of the order.
 * @param {object} res - The HTTP response object.
 * @returns {object} The created order as a JSON response.
 * @throws {Error} If there is an error creating the order.
 */

app.post('/create_order', (req, res) => {
    get_access_token()
        .then(access_token => {
            let order_data_json = {
                'intent': req.body.intent.toUpperCase(),
                'purchase_units': [{
                    'amount': {
                        'currency_code': 'USD',
                        'value': '100.00'
                    }
                }]
            };

            const data = JSON.stringify(order_data_json)

            fetch(endpoint_url + '/v2/checkout/orders', { //https://developer.paypal.com/docs/api/orders/v2/#orders_create
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${access_token}`
                    },
                    body: data
                })
                .then(res => res.json())
                .then(json => {
                    res.send(json);
                }) //Send minimal data to client
        })
        .catch(err => {
            console.log(err);
            res.status(500).send(err)
        })
});

/**
 * Completes an order and returns it as a JSON response.
 * @function
 * @name completeOrder
 * @memberof module:routes
 * @param {object} req - The HTTP request object.
 * @param {object} req.body - The request body containing the order ID and intent.
 * @param {string} req.body.order_id - The ID of the order to complete.
 * @param {string} req.body.intent - The intent of the order.
 * @param {object} res - The HTTP response object.
 * @returns {object} The completed order as a JSON response.
 * @throws {Error} If there is an error completing the order.
 */
app.post('/complete_order', (req, res) => {
    get_access_token()
        .then(access_token => {
            fetch(endpoint_url + '/v2/checkout/orders/' + req.body.order_id + '/' + req.body.intent, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${access_token}`
                    }
                })
                .then(res => res.json())
                .then(json => {
                    console.log(json);
                    res.send(json);
                    // let invoiceNumber = '0001'
                    // MY INSERTIONS HERE - FIRST CREATE INVOICE NUMBER
                    fetch('https://api-m.sandbox.paypal.com/v2/invoicing/generate-next-invoice-number', {
                        method: 'POST',
                        headers: {
                            'Authorization': `Bearer ${access_token}`,
                            'Content-Type': 'application/json'
                        }
                    })
                    .then(response => response.json())
                    .then(data => {
                        console.log(data); // Handle the data (e.g., the invoice number) here
                        let invoiceNumber = data['invoice_number']
                        console.log("invoiceNum: ", invoiceNumber)

                        // ONCE YOU CREATE INVOICE NUM, CREATE THE INVOICE
                        fetch('https://api-m.sandbox.paypal.com/v2/invoicing/invoices', {
                            method: 'POST',
                            headers: {
                                'Authorization': `Bearer ${access_token}`,
                                'Content-Type': 'application/json',
                                'Prefer': 'return=representation'
                            },
                            body: JSON.stringify({ "detail": {
                                                     "invoice_number": invoiceNumber, 
                                                     "reference": "deal-ref", 
                                                    //  "invoice_date": "2018-11-12", 
                                                     "currency_code": "USD", 
                                                     "note": "THIS IS A RECEIPT, not an invoice, please ignore the title", 
                                                     "term": "No refunds after 30 days.", 
                                                     "memo": "This is a long contract", 
                                                    //  "payment_term": { "term_type": "NET_10", "due_date": "2018-11-22" } 
                                                    }, 
                                                     "invoicer": { "name": { "given_name": "Rohan", "surname": "Sehgal" }, 
                                                     "email_address": "sb-e9ro628887181@business.example.com", 
                                                     "phones": [ { "country_code": "001", "national_number": "4087025863", "phone_type": "MOBILE" } ], 
                                                    //  "website": "www.test.com", 
                                                    //  "tax_id": "ABcNkWSfb5ICTt73nD3QON1fnnpgNKBy- Jb5SeuGj185MNNw6g", 
                                                    //  "logo_url": "https://example.com/logo.PNG", 
                                                    //  "additional_notes": "2-4" 
                                                    }, 
                                                    //  "primary_recipients": [ { "billing_info": { "name": { 
                                                    //                                 "given_name": "Stephanie", "surname": "Meyers" }, 
                                                    //                                 "address": { "address_line_1": "1234 Main Street", "admin_area_2": "Anytown", "admin_area_1": "CA", "postal_code": "98765", "country_code": "US" }, 
                                                    //                                 "email_address": "bill-me@example.com", 
                                                    //                                 "phones": [ { "country_code": "001", "national_number": "4884551234", "phone_type": "HOME" } ], "additional_info_value": "add-info" }, 
                                                    //                                 "shipping_info": { "name": { "given_name": "Stephanie", "surname": "Meyers" }, "address": { "address_line_1": "1234 Main Street", "admin_area_2": "Anytown", "admin_area_1": "CA", "postal_code": "98765", "country_code": "US" } } 
                                                    //                             } ], 
                                                    // "due_amount": { "currency_code": 'USD', "value": '100.00' }
                                                                            })
                        })
                        .then(response => response.json())
                        .then(data => {
                            console.log("CREATED INVOICE, time to get receipt")
                            console.log("invoice_id: ", data)
                            let invoice_id = data['id']
                            console.log("the invoice data with no extra json data: ", invoice_id)

                            // // CREATE THE RECEIPT
                            // fetch(`https://api-m.paypal.com/v1/sales/transactions/${invoice_id}/receipt`, {
                            //     method: 'GET',
                            //     headers: {
                            //         'Authorization': `Bearer ${access_token}`,
                            //         'Content-Type': 'application/json'
                            //     }
                            // })
                            // .then(response => response.json())
                            // .then(data => {
                            //     console.log("response: ", data); // Handle the data (e.g., the receipt details) here
                            //     // You can process the receipt details as needed
                            // })
                            // .catch(error => {
                            //     console.error('Error:', error);
                            // });

                            fetch(`https://api-m.sandbox.paypal.com/v2/invoicing/invoices/${invoice_id}/send`, {
                                method: 'POST',
                                headers: {
                                    'Authorization': `Bearer ${access_token}`,
                                    'Content-Type': 'application/json',
                                    'PayPal-Request-Id': 'b1d1f06c7246c'
                                },
                                body: JSON.stringify({ "send_to_invoicer": true , "send_to_recipient": false})
                            })
                            .then(response => response.json())
                            .then(data => {
                                console.log(data)
                                //send link to aws for screenshotting
                                let invoice_link = data['href']
                                //api call goes here
                                fetch(`https://8ov6e25h1b.execute-api.us-west-1.amazonaws.com/v1`, {
                                method: 'POST',
                                body: JSON.stringify({ "invoice_link": invoice_link })
                            })
                            });
                        }); 
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });

                }) //Send minimal data to client
        })
        .catch(err => {
            console.log(err);
            res.status(500).send(err)
        })
});


// Helper / Utility functions

//Servers the index.html file
app.get('/', (req, res) => {
    res.sendFile(process.cwd() + '/index.html');
});
//Servers the style.css file
app.get('/style.css', (req, res) => {
    res.sendFile(process.cwd() + '/style.css');
});
//Servers the script.js file
app.get('/script.js', (req, res) => {
    res.sendFile(process.cwd() + '/script.js');
});

//PayPal Developer YouTube Video:
//How to Retrieve an API Access Token (Node.js)
//https://www.youtube.com/watch?v=HOkkbGSxmp4
function get_access_token() {
    const auth = `${client_id}:${client_secret}`
    const data = 'grant_type=client_credentials'
    return fetch(endpoint_url + '/v1/oauth2/token', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': `Basic ${Buffer.from(auth).toString('base64')}`
            },
            body: data
        })
        .then(res => res.json())
        .then(json => {
            return json.access_token;
        })
}

app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`)
})
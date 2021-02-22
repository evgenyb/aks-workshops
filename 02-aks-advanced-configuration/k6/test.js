import http from 'k6/http';

export let options = {
    stages: [
      { duration: '1m', target: 50 },
      { duration: '1m', target: 150 },
      { duration: '1m', target: 300 },
      { duration: '2m', target: 500 },
      { duration: '3m', target: 50 },
    ],
  };

  var params = {
    headers: {
      'Ocp-Apim-Subscription-Key': 'cc1260b7977e4a839db88f4701c59b1c',
    },
  };

  export default function () {
  let res = http.get('https://iac-ws2-evg-apim.azure-api.net/api', params);
}
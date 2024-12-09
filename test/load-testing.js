import http from 'k6/http';
import { check } from 'k6';

const possibleScenarios = {
    shared_about_scenario: {
        executor: 'constant-arrival-rate',
        duration: '20s',
        preAllocatedVUs: 10,

        env: { URL: `https://${__ENV.DOMAIN}/Base/shared-cluster/about` },
        rate: 10,
        timeUnit: '1s',
    },
    dedicated_test_scenario: {
        executor: 'constant-arrival-rate',
        duration: '20s',
        preAllocatedVUs: 10,

        env: { URL: `https://${__ENV.DOMAIN}/Base/dedicated-cluster/test` },
        rate: 10,
        timeUnit: '1s',
    },
    dedicated_hostname_scenario: {
        executor: 'constant-arrival-rate',
        duration: '20s',
        preAllocatedVUs: 10,

        env: { URL: `https://${__ENV.DOMAIN}/Base/dedicated-cluster/hostname` },
        rate: 10,
        timeUnit: '1s',
    }
};

let enabledScenarios = {};
__ENV.SCENARIOS.split(',').forEach(scenario => enabledScenarios[scenario] = possibleScenarios[scenario]);


export const options = {
    scenarios: enabledScenarios
}
export default function () {

    const url = `${__ENV.URL}`
    const headers = { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${__ENV.TOKEN}`
    };

    const res = http.get(url, { headers });

    check(res, {
        "Get status is 200": (r) => res.status === 200,
    });
}

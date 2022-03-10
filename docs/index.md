---
disqus: ""
--- 
# A random walk away finance

<img src="/images/Adrian.jpg" alt="Mingze Gao" width="30%">
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.3/Chart.min.js" integrity="sha256-R4pqcOYV8lt7snxMQO/HSbVCFRPMdrhAFMH+vr9giYI=" crossorigin="anonymous"></script> -->

- I’m [Mingze Gao](https://mingze-gao.com), aka [Adrian](https://adrian-gao.com), Ph.D. in Finance.
- I now work as a Postdoctoral Research Fellow at the University of Sydney on bank monitoring and risk disclosure with [A/Prof. Buhui Qiu](https://www.sydney.edu.au/business/about/our-people/academic-staff/buhui-qiu.html) and [A/Prof. Eliza Wu](https://www.sydney.edu.au/business/about/our-people/academic-staff/eliza-wu.html) in an Australian Research Council (ARC) Discovery Project (DP).
- I will be on the job market in mid 2023.
- My [CV](https://mingze-gao.com/cv/), [Google Scholar](https://scholar.google.com/citations?user=5n1YYx0AAAAJ&hl=en&oi=ao) and [SSRN Profile](https://papers.ssrn.com/sol3/cf_dev/AbsByAuth.cfm?per_id=2999772).
  <!-- - Authored the Python package [frds - financial research data services](https://github.com/mgao6767/frds). -->
  <!-- - Programmed also the [Interactive Option Pricing](/option-pricing-explained/) and [LeGao - Make LEGO Mosaics](/legao/). -->

**Contact**

- Email: mingze.gao@sydney.edu.au
- Room 516<br>The Codrington Building (H69)
  <br>The University of Sydney NSW 2006

<!-- ---

<canvas id="site-stats" width="400" height="200"></canvas>

<script>
var ctx = document.getElementById('site-stats');
var config = { 
    type: 'line',
    data: {
        labels: [],
        datasets: [{
            label: 'Site Visits',
            data: [],
            backgroundColor: 'rgba(0, 136, 255, 0.4)',
            borderColor: 'rgba(0, 136, 255, 0.8)'
        },
        {
            label: 'Visitors',
            data: [],
        }]
    },
    options: {
        responsive: true,
        legend: {
            display: true
        },
        title: {
            display: true,
            fontFamily: 'Roboto',
            text: '30-Day Site Statistics',
        },
        animation: {duration:1500},
        scales: {
	        yAxes: [{
                ticks: {
                    beginAtZero: true
                }
            }]
        }
    }
};
var myChart = new Chart(ctx, config);
</script> -->

<!-- Load the Embed API library -->
<!-- <script>
(function(w,d,s,g,js,fs){
  g=w.gapi||(w.gapi={});g.analytics={q:[],ready:function(f){this.q.push(f);}};
  js=d.createElement(s);fs=d.getElementsByTagName(s)[0];
  js.src='https://apis.google.com/js/platform.js';
  fs.parentNode.insertBefore(js,fs);js.onload=function(){g.load('analytics');};
}(window,document,'script'));
</script>

<script>
gapi.analytics.ready(function () {
fetch('https://api.adrian-gao.com/ga/access_token')
    .then(response => response.json())
    .then(tokenInfo => {
        gapi.analytics.auth.authorize({
            'serverAuth': {
                'access_token': tokenInfo.token
            }
        });
        var report = new gapi.analytics.report.Data({
            query: {
                'ids': 'ga:169685330',
                'start-date': '30daysAgo',
                'end-date': 'yesterday',
                'metrics': 'ga:sessions,ga:users',
                'dimensions': 'ga:date'
            }
        });
        report.on('success', function (resp) {
            resp.rows.forEach(element => {
                var year = element[0].substring(0, 4);
                var month = element[0].substring(4, 6);
                var day = element[0].substring(6, 8);
                var date = new Date(year, month - 1, day)
                config.data.labels.push(date.toDateString().substring(4, 10));
                config.data.datasets[0].data.push( element[1] );
                config.data.datasets[1].data.push( element[2] );
            });
            myChart.destroy();
            myChart = new Chart(ctx, config);
        });
        report.execute();
    })
});
</script> -->

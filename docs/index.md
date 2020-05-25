# A Random Walk Away Finance.

<img src="/images/Adrian.jpg" alt="Mingze Gao" width="30%">
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.3/Chart.min.js" integrity="sha256-R4pqcOYV8lt7snxMQO/HSbVCFRPMdrhAFMH+vr9giYI=" crossorigin="anonymous"></script>

* I’m [Mingze Gao](https://mingze-gao.com), aka [Adrian](https://adrian-gao.com).
* PhD candidate in Finance at the University of Sydney. 
* Research interests:
    * corporate finance
    * banking
    * market microcstructure
* Here is the place where I randomly write some seriousness or nonsense: 
    * a random walk away finance


**Contact**

* Email: mingze.gao@sydney.edu.au
* Room 236E, Postgraduate Research Centre <br> The Codrington Building (H69)
  <br>The University of Sydney NSW 2006

---

<canvas id="site-stats" width="400" height="200"></canvas>
<script>
var ctx = document.getElementById('site-stats');
var myChart = new Chart(ctx, {
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
        scales: {
        }
    }
});
</script>


<div id="site-stats"></div>

<!-- Load the Embed API library -->
<script>
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
            // console.log(resp.totalsForAllResults);
            resp.rows.forEach(element => {
                var year = element[0].substring(0, 4);
                var month = element[0].substring(4, 6);
                var day = element[0].substring(6, 8);
                var date = new Date(year, month - 1, day)
                myChart.data.labels.push(date.toDateString().substring(4, 10));
                myChart.data.datasets[0].data.push( element[1] );
                myChart.data.datasets[1].data.push( element[2] );

            });
            myChart.update({duration: 10000});
        });
        report.execute();
    })
});
</script>
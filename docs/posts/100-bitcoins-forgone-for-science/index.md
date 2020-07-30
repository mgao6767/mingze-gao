---
ads: true
---

# 100 Bitcoins Forgone for Science

This post is just another piece of my serious nonsense. All of a sudden, I wanted to know how many Bitcoins I could have mined since 2012? This is because I’ve known Bitcoin since its existence in 2009, but have never really put any effort in mining. Instead, I was fascinated by the idea of using distributed (volunteer) computing to solve scientific problems. For example, BOINC and related projects like World Community Grid are using the computing power donated from around the world to find effective treatments for cancer and HIV/AIDS, low-cost water filtration systems and new materials for capturing solar energy efficiently, etc. I was one of the many volunteers for a long time, even before the genesis block of Bitcoin.

An interesting question is, what if I didn’t donate my computers to volunteer computing, but used them in Bitcoin instead? How many Bitcoins I could have mined? To solve this question, I started from looking at my contribution history of the World Community Grid (it’s awesome that the full history is available).

![Historical WCG Points](/images/my-historical-points-generated-from-world-community-grid-projects.png)

According to [WCG’s website](https://www.worldcommunitygrid.org/help/viewTopic.do?shortName=points), 7 WCG Point are equal to 1 BOINC credit, which represents 1/100 day of CPU time on a reference computer that does 1,000 MFLOPS based on the [Whetstone benchmark](https://en.wikipedia.org/wiki/Whetstone_(benchmark)).

However, the defnition of BOINC credit has been changed to 1/200 day of CPU time since 2010, though on WCG’s website it still says the total WCG Points divided by 700 gives the number of GigaFLOPs. I’m going to stick to the WCG’s website for now.

Suppose I’ve got one WCG Point today, then it means my computer has spent 1/700 day of CPU time, i.e. 123 seconds, at a computing rate of 1 GigaFLOP/second. So, if I can convert GigaFLOPs to Bitcoin hashrate, the problem will be quite easy.

However, FLOPs cannot be converted to hashrate in a simple manner as Bitcoin hashes are about integer math, totally different from floating point operations. I’m just going to use a very rough estimate that 1 hash results 12.7k FLOPs (source: [BitcoinTalk thread](https://bitcointalk.org/index.php?topic=50720.0), [CoinDesk](https://www.coindesk.com/bitcoin-network-out-muscles-top-500-supercomputers)), so that

>1 WCG Point implies mining at a speed of 78.7kH/s for 123 seconds.
>-- a very rough estimate

Then, if I received 1k Points a day, it might be safe to say I’ve been mining for about 123k seconds at a speed of 78.7kH/s, which translates to an average daily hashrate of 112kH/s or 0.112MH/s.

I did some math and found that it seems in June 2012 my hashrate was as high as 0.006% of the whole network, though one year later it’s effectively 0%. lol.

![hashrate](/images/hashrate.png)

Next step will be calculating how many Bitcoins I could have mined based on the hashrate history.

Taking into account the average block time and the controlled supply of Bitcoin (table below), I plot the daily average number of blocks and Bitcoins generated in this period.

| Date reached | Block  | Reward Era | BTC/block | End BTC % of Limit |
| ------------ | ------ | ---------- | --------- | ------------------ |
| 2009-01-03   | 0      | 1          | 50.00     | 12.500%            |
| 2010-04-22   | 52500  | 1          | 50.00     | 25.000%            |
| 2011-01-28   | 105000 | 1          | 50.00     | 37.500%            |
| 2011-12-14   | 157500 | 1          | 50.00     | 50.000%            |
| 2012-11-28   | 210000 | 2          | 25.00     | 56.250%            |
| 2013-10-09   | 262500 | 2          | 25.00     | 62.500%            |
| 2014-08-11   | 315000 | 2          | 25.00     | 68.750%            |
| 2015-07-29   | 367500 | 2          | 25.00     | 75.000%            |
| 2016-07-09   | 420000 | 3          | 12.50     | 78.125%            |
| 2017-06-23   | 472500 | 3          | 12.50     | 81.250%            |
| 2018-05-29   | 525000 | 3          | 12.50     | 84.375%            |

![block rate](/images/the-daily-average-number-of-blocks-and-bitcoins-generated.png)

Based my average hashrate and the historical network hashrate, the plot below shows how many Bitcoins I could have mined if I didn’t denote my computers’ computing power to the World Community Grid but to Bitcoin mining – **14.8 Bitcoins**!

![bitcoins forgone](/images/the-numer-of-bitcoins-i-could-have-mined.png)

Okay, problem solved.

If I’ve really mined these 14.8 Bitcoins, then I’ll probably have a shot at becoming a millionaire, if again I could hold them and time the market perfectly. At Bitcoin’s highest historical price in Australian dollar, 14.8 Bitcoins are roughly **380,505 dollars**. Even if I follow the redefined BOINC credit, I still could have mined half of the 14.8 Bitcoins and potentially pocketed 190k dollars.

I’ve also participated in more than just World Community Grid, including some famous ones like [SETI@Home](https://setiathome.berkeley.edu/) and [Einstein@Home](https://einsteinathome.org/). Below are two certificates of contributed computing power.

![SETI](/images/seti.jpg)

![Einstein](/images/einstein.jpg)

So together I’ve put in about **2.28 quintillion**, or 2.28E18, FLOPs into these two projects.

The funny thing is that I’ve put in only 348 PetaFLOPs into World Community Grid during this entire period, or **0.348 quintillion** FLOPs in total.

Hence, if my donation of computing power to SETI@Home and Einstein@Home happened at similar time as to WCG, then potentially I could have mined at least **6 times** more Bitcoins. Well, I couldn’t imagine what my life would be if I’ve mined **100 Bitcoins**, which might be **$2.5 million**.

![sad](/images/computer-guy.png)
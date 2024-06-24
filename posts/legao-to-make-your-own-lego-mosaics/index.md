---
title: LeGao to Make Your Own LEGO Mosaics
date: 2020-05-22
date-modified: Sep 29, 2022
tags:
  - Apps
---

I made an online app that turns a picture into a LEGO mosaic: [mingze-gao.com/legao](https://mingze-gao.com/legao).

<!-- more -->

A few weeks ago, I went to the new LEGO flagship store at Bondi with my fiancée, Sherry, and we were impressed by the LEGO Mosaics -- Sydney Harbour Bridge and Opera House in sunset, designed by Ryan McNaught.

![LEGO Sydney Bridge (credit: jaysbrickblog.com)](/images/LEGO-Store-Sydney-Harbour-Bridge-Mural-1024x662.jpg)

This mosaic is made of 62,300 bricks and took 282 hours to build. Every single pixel is a ~~1x1~~ LEGO brick! We love it so much so that I'm thinking of making one myself and use it to decorate a wall in our apartment in the future.

To begin this endeavour, I'll need a handy tool to convert pictures to LEGO mosaic so that I can have a preview and the data to assemble later. It turns out that there's already an open-source library named [legofy](https://github.com/JuanPotato/Legofy) for this job. So I borrowed it and wrote a small Flask app on my server to do the magic.

I wrote the frontend using [React](https://reactjs.org/) and [Ant Design](https://ant.design/), and picked up the [React Hooks](https://reactjs.org/docs/hooks-intro.html) along the way. It was great fun. I named it using a combination of *LEGO* and my surname *Gao*, so, **LeGao**.

Now, LeGao is served at [mingze-gao.com/legao](https://mingze-gao.com/legao). A preview is as below:

![LeGao-1](/images/LeGao-1.jpg)

Users can upload an image(<5MB) and decide on which palette to use and how many 1x1 bricks the output image should have for its longest axis. This is useful when we need to make a LEGO mosaic in real world, as a 1x1 brick's dimension is about 8mm x 8mm.

![LeGao-2](/images/LeGao-2.jpg)

The output image can be downloaded, no problem. All images will be deleted from my server after 5 minutes since upload/creation for privacy concern and the fact that my server doesn't have a big storage.

LeGao also tells you about how many bricks you'll need to assemble the mosaic, if you really want to. Then you can easily order the bricks online or visit a store to purchase them all~

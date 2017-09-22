From: Allen <allen.lkml@gmail.com>
Date: Fri, 22 Sep 2017 11:48:24 +0000
Subject: Re: [PATCH 0/3] use setup_timer() helper function.
Message-Id: <CAOMdWSLgiTgye0fQPG988cjXoPkx6NHVdCtvNkBxnkVtZgHyMQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1506079562-5068-1-git-send-email-allen.lkml@gmail.com>
In-Reply-To: <1506079562-5068-1-git-send-email-allen.lkml@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This series uses setup_timer() helper function. The series
> addresses the files under drivers/block/*.
my bad, this should have been arch/ia64/*

- Allen

>
> Allen Pais (3):
>   ia64: bte: use setup_timer() helper.
>   ia64: mca: use setup_timer() helper.
>   ia64: salinfo: use setup_timer() helper.
>
>  arch/ia64/kernel/salinfo.c | 3 +--
>  arch/ia64/sn/kernel/bte.c  | 5 ++---
>  arch/ia64/sn/kernel/mca.c  | 3 +--
>  3 files changed, 4 insertions(+), 7 deletions(-)
>
> --
> 2.7.4
>



-- 
       - Allen

From: Bill Nottingham <notting@redhat.com>
Date: Fri, 29 Jun 2001 14:05:50 +0000
Subject: [Linux-ia64] Re: framebuffer
Message-Id: <marc-linux-ia64-105590693005804@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I had a B2-machine that is running RedHat Linux Beta7.0.98(Wolverine). 
> I updated kernel2.4.5 and patched ia64-010626.
> 
> Does anyone know how to use framebuffer?

It's a module in our builds, so you can just modprobe
aty128fb, for example.

Bill


From: "John Hawkes" <hawkes@sgi.com>
Date: Sun, 18 Sep 2005 21:43:55 +0000
Subject: Re: Volanomark regress on ia64
Message-Id: <00cd01c5bc9a$12297720$6f00a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509160040.j8G0eFg06734@unix-os.sc.intel.com>
In-Reply-To: <200509160040.j8G0eFg06734@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am also seeing a degradation of 16% @48p and 9% @32p for my favorite AIM7
workload on ia64 (SGI SN/Altix) between 2.6.13-rc6 and 2.6.14-rc1.  I haven't
peeked beneath the covers to analyze why it's happening.  I've still been
gathering performance numbers.

John Hawkes


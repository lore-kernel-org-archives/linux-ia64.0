From: Keith Owens <kaos@sgi.com>
Date: Mon, 23 Feb 2004 23:28:57 +0000
Subject: Re: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <1558.1077578937@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4545.1077507994@kao2.melbourne.sgi.com>
In-Reply-To: <4545.1077507994@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Feb 2004 15:09:38 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>In case it wasn't clear: if you want things to be in sync, I'd rather
>ask Bjorn to remove the KDB portions in unwind.c.

Trust me, it was clear ;)  There are some 2.4 unwind patches in flight
right now, once they are sorted I will move the kdb code from unwind.c
to the kdb patch.


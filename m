From: "David S. Miller" <davem@redhat.com>
Date: Wed, 24 Sep 2003 02:55:21 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106437317407309@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 10:56:33 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> An event that causes a slow-down of 500 times or so is not "normal".

For the slow path of IP option processing it is.  When using IP
embedded in appletalk, it is.

It's all slow path stuff.

Why is this so hard to understand?

From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 19:11:16 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434575613160@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 11:06:04 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> So what's wrong with doign prctl --fpemul=silent in the init process?
> The flags are inherited across fork().

Great, can we get such a setting for the kernel bits too?

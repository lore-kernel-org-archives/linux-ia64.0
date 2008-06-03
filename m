From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 03 Jun 2008 16:23:16 +0000
Subject: Re: [patch] fix bootmem regression on Altix
Message-Id: <48456FF4.6030502@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080424181659.GB5211@sgi.com>
In-Reply-To: <20080424181659.GB5211@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> On Tue, Jun 03, 2008 at 10:56:10AM +0200, Petr Tesarik wrote:
> Russ Anderson wrote:
>>>> [patch] fix bootmem regression on Altix
>>>>
>>>> A recent change prevents SGI Altix from booting.
>>>> This patch fixes the problem.
>>>>
>>>> The regresson was introduced in commit 434d53b00d6bb7be0a1d3dcc0d0d5df6c042e164
> Could we get this into mainline?
> 
>> Which mainline tree?  Tony pushed the patch to Linus back on 4/24
>> and I see it in Linus' tree.
> 
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;hG2613b961affef0c73f1c797993678312e7c666
>

Ooops, forget it, I screwed up the bisect branch and the change was
apparently no longer there. After git reset --hard, I can see it correctly.

Sorry for the fuss,
Petr Tesarik


From: Andi Kleen <ak@suse.de>
Date: Tue, 21 Sep 2004 20:14:25 +0000
Subject: Re: page fault scalability patch V8: [4/7] universally available cmpxchg on i386
Message-Id: <20040921201425.GH18938@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <200409211841.25507.vda@port.imtp.ilyichevsk.odessa.ua> <20040921154542.GB12132@wotan.suse.de> <200409212306.38800.vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200409212306.38800.vda@port.imtp.ilyichevsk.odessa.ua>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, benh@kernel.crashing.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

> Looks like indirect jump is only slightly slower (on this CPU).

K7/K8 can predict indirect jumps. But most P3 and P4s can't (except for
the new Prescotts and Centrinos). And in all cases their jump predictor works 
worse.

-Andi

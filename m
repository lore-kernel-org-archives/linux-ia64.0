From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 15 Jun 2004 16:59:31 +0000
Subject: Re: bus_features in palinfo.c
Message-Id: <20040615165931.GB14461@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40C425EB.40703@bull.net>
In-Reply-To: <40C425EB.40703@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Guy,

On Mon, Jun 07, 2004 at 10:23:07AM +0200, Guy Sauvebois wrote:
> 
> If i read well, bus_features table in palinfo.c decribes
> bit 52 as "Enable Cache Line Repl. Exclusive"
> bit 53 as "Enable Cache Line Repl. Shared"
> and Intel documentation System Architecture vol 2 (table 11-25)
> defines bit 52 as "shared" and bit 53 as "exclusive".
> what's right ? Intel doc I think
> thanks

Yes, there is a bug in palinfo.c. I submitted a patch to David
for 2.6 and I will submit to Bjorn for 2.4 as well.

Thanks.

-- 
-Stephane

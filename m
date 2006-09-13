From: Jes Sorensen <jes@sgi.com>
Date: Wed, 13 Sep 2006 09:52:46 +0000
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-Id: <4507D4EE.4060501@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Wed, 13 Sep 2006, Jes Sorensen wrote:
> 
>>>>>>> "Christoph" = Christoph Lameter <clameter@sgi.com> writes:
>> Christoph> It is true for a large range of hardware. My x86 x64
>> Christoph> systems do not need the DMA zone and I have been running
>> Christoph> them for awhile in this mode. Some drivers are not
>> Christoph> available as a result of not having ZONE_DMA.
>>
>> Any idea which ones?
> 
> There was the floppy driver and one type of USB stick that I noticed 
> during the work on the project. But other drivers may depend also depend 
> indirectly on DMA functionality and may also be disabled.

Ok, USB should ring alarm bells, floppy I think is less relevant these
days :)

Cheers,
Jes


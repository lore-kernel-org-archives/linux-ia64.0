From: Horms <horms@verge.net.au>
Date: Wed, 30 Aug 2006 08:27:19 +0000
Subject: Re: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <20060830082717.GA21121@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156837594.2598.15.camel@linux-znh>
In-Reply-To: <1156837594.2598.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 30 Aug 2006 06:03:23 +0800, Zou Nan hai wrote:
> On Wed, 2006-08-30 at 03:38, Bjorn Helgaas wrote:
>> On Tuesday 29 August 2006 01:46, Zou Nan hai wrote:
>> > +#ifdef CONFIG_KEXEC
>> > +void
>> > +ioc_iova_disable(void)
>> > +{
>> 
>> Ugh.  If you really need this functionality (which I have to say
>> looks
>> like a band-aid), it probably should be a platform vector.  And
>> should
>> be split into a separate patch.
>> 
> Hi Bjorn,
>        The ioc_iova_disable code comes from Aziz in HP, I have almost
>        no idea
> of how IOMMU works on HP platform.
> I am looking for an HP machine with IOMMU to test. 

That sounds like even more reason to break it out into a separate patch.

Actually, I really think that you sould either provide a set or smaller
patches, or incremental patches. Its quite hard to follow what is
changing with the current jumbo-patch format.

Its also quite unclear what if any portions you would like merged, and
even which tree you want them merged into - you patches are against 
2.6.18-rc5, but the ia64 tree seems the most likely path, and your code
doesn't apply there because some of the changes are already present.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

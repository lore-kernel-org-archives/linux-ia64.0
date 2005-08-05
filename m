From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 05 Aug 2005 17:49:37 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <yq0ek98ff4e.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> + if (md->type = EFI_BOOT_SERVICES_DATA && + md->attribute =
>> EFI_MEMORY_UC) {

Tony> That will certainly stop this code from crashing on Tiger.

Tony> But it still doesn't really do what the comment claims it will
Tony> do.  The "attribute" field is a bitmask ... most of the memory
Tony> that was dropped because of holes or incompatible attributes
Tony> within the same granule will also have other allowable
Tony> attributes.  So final version of this should be checking
Tony> "md->attribute & EFI_MEMORY_UC" rather than "=".

Ok,

I don't have all the EFI specs at hand, didn't realize it was a
bitmask. We should probably combine that with something like what Alex
Williamson was suggesting.

Cheers,
Jes

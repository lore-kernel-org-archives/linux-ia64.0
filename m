From: Matthew Wilcox <willy@debian.org>
Date: Tue, 02 Mar 2004 15:56:01 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <20040302155601.GI25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 01, 2004 at 11:46:22PM -0800, David Mosberger wrote:
> Well, this patch is giving me lots of grief.  It appears that old
> (prototype) zx1 systems report a huge SAL version:
> 
> 	SAL 49.29: INTEL   MSL     REF     SAL      version 49.29
> 
> Unfortunately, the hardware is too old to upgrade to newer firmware,
> yet the hardware is good enough to be useful.  Perhaps we could have a
> command-line option to override the SAL version?

I don't have an objection to doing that, but how about making it Just
Work for this particular case?  Something like ..

static void check_versions(struct ia64_sal_systab *systab)
{
        sal_revision = (systab->sal_rev_major << 8) | systab->sal_rev_minor;
        sal_version = (systab->sal_b_rev_major << 8) | systab->sal_b_rev_minor;

        /* Check for broken firmware */
        if ((sal_revision = SAL_VERSION_CODE(49, 29)) &&
                        (sal_version = SAL_VERSION_CODE(49, 29))) {
                sal_revision = SAL_VERSION_CODE(2, 8);
                sal_version = SAL_VERSION_CODE(0, 0);
        }
}

...
        if (strncmp(systab->signature, "SST_", 4) != 0)
                printk(KERN_ERR "bad signature in system table!");

        check_versions(systab);

        /* revisions are coded in BCD, so %x does the job for us */ 
        printk(KERN_INFO "SAL %x.%x: %.32s %.32s%sversion %x.%x\n",
...

SAL rev 2.8 was published in January 2000.  It should be safe to claim
compliance with this.  The version number change I'm not 100% sure of,
but it seems better than leaving it too high.

(I note this fix shows the wisdom of going with the SAL_VERSION_CODE
option.  Good call.)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain

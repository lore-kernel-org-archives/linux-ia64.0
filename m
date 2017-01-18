From: Borislav Petkov <bp@suse.de>
Date: Wed, 18 Jan 2017 11:29:51 +0000
Subject: Re: [PATCH v7 02/14] xtensa: skip adding literal when SORT() is used
Message-Id: <20170118112951.62drjsk264rhe5lj@pd.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
 <20170115211057.17167-3-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-3-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: gnomes@lxorguk.ukuu.org.uk, dalias@libc.org, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, mpe@ellerman.id.au, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, linux@arm.linux.org.uk, linux-sh@vger.kernel.org, will.deacon@arm.com, korea.drzix@gmail.com, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, mingo@redhat.com, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux@roeck-us.net, david.vrabel@citrix.com, linux-xte

On Sun, Jan 15, 2017 at 01:10:45PM -0800, Luis R. Rodriguez wrote:
> When SORT(foo.*) is used the current sed replacements add
> SORT(foo.literal foo.*), this breaks linking. Avoid adding
> literals for SORT globs, if needed, these need to be added
> manually.

Please rewrite this commit message by breaking into separate sentences,
adding punctuation, etc.

Also, "the current sed replacements add" sounds really strange and makes
me wonder what do you mean. What are "sed replacements"? I think you
mean the "sed regex adds" from looking at the diff.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
-- 

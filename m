From: Jes Sorensen <jes@sgi.com>
Date: Wed, 08 Feb 2006 13:38:57 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <yq0d5hym0lq.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060208035112.GM3524@stusta.de>
	<200602080552.k185q9g07813@unix-os.sc.intel.com>
	<20060208115946.GN3524@stusta.de>
In-Reply-To: <20060208115946.GN3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Keith Owens' <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Adrian" = Adrian Bunk <bunk@stusta.de> writes:

Adrian> On Tue, Feb 07, 2006 at 09:52:09PM -0800, Chen, Kenneth W
Adrian> wrote:
>> But for the bit that this thread started, which disables
>> CONFIG_MCKINLEY for CONFIG_IA64_GENERIC, it is totally wrong and is
>> the "over my dead body" type of thing.

Adrian> My initial patch that started this thread was to remove all
Adrian> select's from CONFIG_IA64_GENERIC.

Adrian> Is this OK for you?

Adrian,

Not really, it helps a bit by selecting some things we know we need
for all GENERIC builds. True we can't make it bullet proof, but whats
there is better than removing it.

Jes

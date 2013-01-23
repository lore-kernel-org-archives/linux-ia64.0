From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Wed, 23 Jan 2013 11:40:59 +0000
Subject: Re: [PATCH v4 00/13] Add gdb python scripts as kernel debugging helpers
Message-Id: <50FFCC4B.10105@siemens.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1358787929.git.jan.kiszka@siemens.com> <20130123113221.GA4256@pd.tnic>
In-Reply-To: <20130123113221.GA4256@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On 2013-01-23 12:32, Borislav Petkov wrote:
> Ok, first of all, I gotta say, this is very cool stuff, thanks for doing
> this. I'm playing with your tutorial and I'm having some trouble, see
> below:
> 
> On Mon, Jan 21, 2013 at 06:06:07PM +0100, Jan Kiszka wrote:
>>  o Let's examine the current task a bit:
>>     (gdb) p ().pid
> 
> when I do that, it says:
> 
> (gdb) p ().pid
> A syntax error in expression, near `).pid'

Ouch, my git-send script ate all the "$foo" in the cover letter :(. It
has to be $lx_current, $lx_per_cpu and $container_of. Will write an
add-on patch that adds the tutorial as a text file later on.

Jan

-- 
Siemens AG, Corporate Technology, CT RTC ITP SDP-DE
Corporate Competence Center Embedded Linux

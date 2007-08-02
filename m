From: Al Viro <viro@ftp.linux.org.uk>
Date: Thu, 02 Aug 2007 19:39:03 +0000
Subject: Re: scripts/mod/file2alias.c cross compile problem
Message-Id: <20070802193903.GN21089@ftp.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <jewswdvqpt.fsf@sykes.suse.de> <617E1C2C70743745A92448908E030B2A02156CC1@scsmsx411.amr.corp.intel.com> <20070802180903.GD2431@uranus.ravnborg.org> <20070802191509.GX3972@stusta.de> <20070802192456.GA3509@uranus.ravnborg.org>
In-Reply-To: <20070802192456.GA3509@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Adrian Bunk <bunk@stusta.de>, "Luck, Tony" <tony.luck@intel.com>, Andreas Schwab <schwab@suse.de>, trenn@suse.de, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, rusty@rustcorp.com.au, jcm@jonmasters.org

On Thu, Aug 02, 2007 at 09:24:56PM +0200, Sam Ravnborg wrote:
> I am well aware of that.
> My point was that we are dealing with userspace - in this case depmod.
> So I wondered why we had special (as in less strict) rules here.

In reality it's a pointer...

From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 18 Jun 2003 20:32:47 +0000
Subject: Re: common name for the kernel DSO
Message-Id: <marc-linux-ia64-105596844302193@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105596373129064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105596373129064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2003 at 12:12:21PM -0700, David Mosberger wrote:
> Not surprisingly, I like the name "linux-gate", since that is really
> what this DSO is all about: it's a gateway between user and kernel
> space.  However, if this name isn't appropriate for x86, perhaps we
> can find another name which will be acceptable to everybody.

Hi David.

I see no clean way to share the rules between the architectures,
at least not without doing something very special for this.
The second best alternative is to have the same implementation
in all architectures supporting this, so my vote goes for the
gate name.

PS. One day I hope to find a better solution for the gross ld_flags hack..

	Sam

From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 Apr 2004 23:38:02 +0000
Subject: Re: local symbol 0: discarded in section `.exit.text' from drivers/built-in.o
Message-Id: <16501.57946.120317.246675@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040408003018.42418a33.akpm@osdl.org>
In-Reply-To: <20040408003018.42418a33.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 Apr 2004 08:32:34 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> On Thursday, April 8, 2004 12:30 am, Andrew Morton wrote:
  >> Also, I am heartily sick of this gunk from the assembler:

  >> {standard input}:20882: Warning: This is the location of the conflicting
  >> usage  {standard input}:20917: Warning: Use of 'ld4' may violate RAW
  >> dependency 'DBR#' (data) {standard input}:20917: Warning: Only the first
  >> path encountering the conflict is reported {standard input}:20882: Warning:
  >> This is the location of the conflicting usage {standard input}:20917:
  >> Warning: Use of 'ld4' may violate RAW dependency 'DBR#' (data)

  >> Has that been fixed yet?  If so, which is a good version of binutils to
  >> start using?

  Jesse> H.J. said he'd fix it when he had time, I think it involves a
  Jesse> rewrite of the dependency checking code in binutils.

I don't think it's a "fix" as much as a new feature.  AFAIK, there is
currently know way to say that those apparent RAWs really an
issue (because we're in kernel space and the breakpoints are setup
for user-level).

It probably would be good to have an assembler directive to turn off
dependency-checking.  A bit dangerous, but it's probably too complicated
to have more fine-grained control for all the system stuff.

  Jesse> I ended up compiling binutils with this hack to avoid the
  Jesse> checks altogether.

Rather dangerous.  I don't like the warnings either, but a missed true
dependency violation is even worse.  Just ask Don Dugger or Asit how
much fun they had tracking down such bugs before GAS supported the
dependency-checking.

	--david

From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 Aug 2002 18:30:15 +0000
Subject: Re: [Linux-ia64] [RFC] Remove MCA dump?
Message-Id: <marc-linux-ia64-105590701905971@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Aug 2002 13:38:32 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Wed, Aug 21, 2002 at 02:34:42PM +0200, Andreas Schwab
  Matthew> wrote:
  >> Matthew Wilcox <willy@debian.org> writes:
  >> 
  >> |> The MCA handler is completely useless.  If I crash the machine
  >> and |> forget to clear the MCA dump in firmware, at the next boot
  >> Linux dumps |> the registers (in a hard-to-understand style) and
  >> hangs.
  >> 
  >> I haven't seen such hangs on our machines, except for some old
  >> pre-production systems that lack the necessary hardware support.

  Matthew> I wonder why not.  Here's the code:

  Matthew> void init_handler_platform (struct pt_regs *regs) { /* if a
  Matthew> kernel debugger is available call it here else just dump
  Matthew> the reg isters */

  Matthew>         show_regs(regs); /* dump the state info */ while
  Matthew> (1); /* hang city if no debugger */ }

  Matthew> Maybe it only locks up that specific processor so you
  Matthew> didn't notice you'd lost a processor on an SMP system?

This endless loop happens only in response to an INIT event.  The
boot-time MCA dump does not go through this path.

	--david


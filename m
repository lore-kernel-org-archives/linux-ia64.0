From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Tue, 24 Jul 2001 17:48:04 +0000
Subject: [Linux-ia64] Kernel configuration
Message-Id: <marc-linux-ia64-105590693005902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Going through yet another kernel config iteration,
I just wondered whether we should try to compile
a list of ia64-compatible kernel config options.

Itanium boxes will soon be available to a larger public,
and anybody who tries to configure his own kernel
will be confronted with the fact that many options
in the current kernel result in compile-time or run-time
errors.

I would suggest that we:

- compile a "positive list" that contains all drivers,
  file systems, ... known to work flawlessly with
  IA64. One might even want to distinguish between
  modules that compile and modules that are well-tested
  in running systems (I feel these are non-identical sets).

- (perhaps) compile a "negative" list with "avoid
  this option on IA-64 at all costs" options.

The results could then go into a file under "Documentation".

Opinions?

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113





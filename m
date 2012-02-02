From: Richard Guenther <rguenther@suse.de>
Date: Thu, 02 Feb 2012 09:46:50 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <alpine.LNX.2.00.1202021045100.4999@zhemvz.fhfr.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com> <1328118174.15992.6206.camel@triegel.csb> <20120201194025.GG6148@sunsite.ms.mff.cuni.cz> <CA+55aFzVWjqcs1zRF-93_9yHRDS-YgmpgFTzACw6HQ-059U06Q@mail.gmail.com>
 <CA+55aFwG7BoFg-zaER7=hiamX62_zZCQhB_A+edHaK9Sj7Ga0g@mail.gmail.com>
In-Reply-To: <CA+55aFwG7BoFg-zaER7=hiamX62_zZCQhB_A+edHaK9Sj7Ga0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jakub Jelinek <jakub@redhat.com>, Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, gcc@gcc.gnu.org

On Wed, 1 Feb 2012, Linus Torvalds wrote:

> IT IS A GCC BUG.

I think you are wrong when you assume that we think it is not a bug.
Repeating it repeatedly in all-caps doesn't make the fix appear
faster though.

Richard.

From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 21 Feb 2022 20:06:29 +0000
Subject: Re: [PATCH v4 00/13] Fix LKDTM for PPC64/IA64/PARISC v4
Message-Id: <5326a8e6-3888-dca4-7e7f-73a85d53aa68@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
 <9cac37da-f719-13f8-1a21-2aac7a574479@physik.fu-berlin.de>
In-Reply-To: <9cac37da-f719-13f8-1a21-2aac7a574479@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Hi!

On 2/16/22 13:25, John Paul Adrian Glaubitz wrote:
>> This series does some cleanup in the three architectures and
>> refactors function descriptors so that it can then easily use it
>> in a generic way in LKDTM.
> 
> I'll test the series on ia64 later this week. I have an Itanium box at
> home for testing kernel patches.

Series applied on top of 038101e6b2cd5c55f888f85db42ea2ad3aecb4b6 and
successfully tested on my HP Integrity RX2600 server.

Tested-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

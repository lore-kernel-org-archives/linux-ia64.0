From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 28 Jan 2002 08:56:27 +0000
Subject: [Linux-ia64] Offsets from C struct into assembler
Message-Id: <marc-linux-ia64-105590698805940@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

Does anyone know how to bring offsets from a C structure into pure
assembly code (not inline-asm)?
I want to do something like:

struct abc {
    ...
    long varx;
    ...
    }

add rx=offset(varx),ry    // get address of variable
ld8 rx=[rx]                    // get variable varx

with ry being the base address of the structure abc and offset_varx
beeing compiled from struct abc.

Any ideas are welcome.

Christian



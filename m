From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 11 Aug 2003 02:07:02 +0000
Subject: Re: [PATCH] Kill `unused variable' warnings in unistd.h (2.6.0-testX)
Message-Id: <marc-linux-ia64-106056775232323@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106056471130687@msgid-missing>
In-Reply-To: <marc-linux-ia64-106056471130687@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 11 Aug 2003 11:17:48 +1000, 
Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
>+#define __STRINGIFY(x) #x
>+#define _STRINGIFY(x) __STRINGIFY(x)

Replace with
#include <linux/stringify.h>


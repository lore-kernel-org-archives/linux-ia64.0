From: Jes Sorensen <jes@linuxcare.com>
Date: Tue, 08 Aug 2000 18:55:41 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Uros" = Uros Prestor <uros@turbolinux.com> writes:

Uros> On another note, we are getting a lot more segfaults during
Uros> builds lately.  The 0505 release which had the 2.3.99-pre6
Uros> kernel was rock solid; after moving to 2.4.0 kernels the
Uros> segfaults came back with a vengeance.  We did upgrade processors
Uros> from A2 to A3 but I don't think this could be a culprit.  Any
Uros> ideas on this?

Did you upgrade the compiler as well to a more recent snapshot? Did
you include Dan's hand optimized string/mem routines in your glibc
package?

Jes


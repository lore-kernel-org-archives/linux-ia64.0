From: "Kenneth Chen" <kenneth.w.chen@intel.com>
Date: Thu, 11 Mar 2004 18:37:49 +0000
Subject: RE: 2.6.3 compilation problem
Message-Id: <200403111837.i2BIbmm03376@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> Liu, Benjamin wrote on Thu, March 11, 2004 12:33 AM
> To workaround the problem, you can append __attribute__((weak)) to the
> declaration of those discarded symbols defined in section ".exit.text".
>
> The device driver author might be able to answer why it is written that
> way.

The linker gets the award for least informative in this case, and it just
plain misleading.  The culprit isn't the one printed.  It lies somewhere
else.

- Ken



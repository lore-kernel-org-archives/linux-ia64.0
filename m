From: "G\\351raud Krawezik" <gk@scali.no>
Date: Wed, 16 Aug 2000 11:59:27 +0000
Subject: [Linux-ia64] Exporting symbol in linux2.4/ia64
Message-Id: <marc-linux-ia64-105590678205335@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on a driver, I've experienced the following when trying to
insmod it (i'm using 2.4-test6):

unresolved symbol clear_page
unresolved symbol softirq_state
unresolved symbol __ia64_memcpy_toio
unresolved symbol __free_pages_ok

softirq_state is a 'case to study', but for the three others, it's
slightly different, as:

clear_page exists in the kernel (nm vmlinux...) but is probably not
exported
__free_pages_ok is present as well, but should be available through a
'classic' function (no __)
__ia64_memcpy_toio does not exist in vmlinux, neither memcpy_toio...
ld problem?

As on 2.2/ia32 I had no problem with clear_page, free_page_ok and
memcpy_toio, I guess that it's just an exporting problem. Now I'm
including directly the object into my driver to debug it, but could you
tell me if in the final release those symbols will remain unexported or
not? (ie: is it just a bug?)


Thanks...

Geraud



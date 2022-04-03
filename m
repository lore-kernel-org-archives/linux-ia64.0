From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 03 Apr 2022 05:48:19 +0000
Subject: [PATCH 0/3 v3] Documentation: kernel-parameters: alphabetize and misc. fixes
Message-Id: <20220403054822.16868-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, linux-s390@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-ia64@vger.kernel.org, "Rafael J. Wysocki" <rafael@kernel.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <lenb@kernel.org>, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org

Alphabetize parts of kernel-parameters.txt. Alphabetize the "legends"
in kernel-parameters.rst. Add a few and drop a few outdated legends.


 [PATCH 1/3 v3] Docs: admin/kernel-parameters: edit a few boot options
 [PATCH 2/3 v3] Docs/admin: alphabetize some kernel-parameters (part 1)
 [PATCH 3/3 v3] docs/admin: alphabetize parts of kernel-parameters.txt (part 2)

 Documentation/admin-guide/kernel-parameters.rst |   11 
 Documentation/admin-guide/kernel-parameters.txt |  326 +++++++-------
 2 files changed, 180 insertions(+), 157 deletions(-)


Cc: Heiko Carstens <hca@linux.ibm.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Alexander Gordeev <agordeev@linux.ibm.com>
Cc: Christian Borntraeger <borntraeger@linux.ibm.com>
Cc: Sven Schnelle <svens@linux.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-ia64@vger.kernel.org
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Len Brown <lenb@kernel.org>
Cc: linux-pm@vger.kernel.org
Cc: linux-acpi@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org

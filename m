From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 19 Nov 2001 09:11:08 +0000
Subject: [Linux-ia64] Fixed addresses in kernel address space
Message-Id: <marc-linux-ia64-105590698805533@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi everybody!

For a driver I am writing, I would need access to some storage below
e000000004400000. There is a range from e000000004000000 to
e000000004400000 that is mapped by the kernel translation but not used
in system.map (kernel 2.4.4). Is it possible to use part of this storage
or are there restrictions/other usage? Can I rely on this unused storage
in the future or is this subject to change?

Any help would be appreciated.

Christian



From: Andy Isaacson <adi@hexapodia.org>
Date: Wed, 05 Mar 2003 23:30:01 +0000
Subject: [Linux-ia64] munmap() slowness
Message-Id: <marc-linux-ia64-105590709805979@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

munmap on a 15TB anonymous area is extremely slow on our Itanium 2 box.

#include <sys/mman.h>
int main(void) {
    size_t s = 1024*1024*1024*1024L * 15;
    munmap(mmap(0, s, PROT_READ|PROT_WRITE,
                MAP_NORESERVE|MAP_PRIVATE|MAP_ANONYMOUS, -1, 0),
           s);
    return 0;
}

./a.out 0.00s user 1.51s system 100% cpu 1.515 total

The kernel is 2.4.19 plus linux-2.4.19-ia64-020821.diff.gz (plus some
local changes that shouldn't be relevant).

Of course this isn't a real app, but I thought this was an interesting
result.

Please CC me on any replies, as I am not subscribed to the list.

-andy


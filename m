From: David Robboy <robboy@co.intel.com>
Date: Mon, 24 Apr 2000 23:31:40 +0000
Subject: [Linux-ia64] Bug report: two 'kills' kill the shell
Message-Id: <marc-linux-ia64-105590678205029@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On MP linux 2.3.47 for ia64 running on a 4-processor system, with this
program:

main()
{
        while(1)
        {
                sleep(2);
                printf("Hello world\n");
        }
}

I started  up 4 of them in background from one shell.  Then went to another
window and started killing them with the 'kill' command (not kill 9, just
plain kill).  The second 'kill' kills the shell, consistently.  It looks
like maybe the shell can handle one SIGCHILD but not two of them.

David Robboy




From: "Jeremiah Gowdy" <jgowdy@home.com>
Date: Thu, 09 Aug 2001 02:29:09 +0000
Subject: [Linux-ia64] Branch Registers and Calls
Message-Id: <marc-linux-ia64-105590698805046@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have a quick question.  I am preparing a presentation on the security
implications of the new IA-64 architecture.  In reading the IA-64 specs from
Intel, I know that when you jump/branch, the destination is in a branch
register.  What I'm trying to figure out is this: When you make a procedure
call (br.call) where does it store the return IP ?  Is it stored in a branch
register or is it pushed onto the stack ?  As I'm sure most are aware, the
design of pushing the IP onto the stack is what allows a majority of
security exploits to work.  I believe that if it is stored in a branch
register, or even dumped into a non-accessable portion of memory, rather
than being stored on the stack, this would prevent the most common buffer
overflow overwrites of the return IP.  If it is stored in a branch register,
are they eventually dumped into memory when there are no longer enough
branch registers, just like alloc with integer registers ?  Do any of you
see any other security implications of this new architecture that I might be
missing ?  Any help greatly appriciated.  I will be mentioning your site in
my presentation.




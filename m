From: Jens Axboe <axboe@kernel.dk>
Date: Fri, 01 Jan 2021 15:08:09 +0000
Subject: Re: [PATCH] sh: add support for TIF_NOTIFY_SIGNAL
Message-Id: <23bf4423-0987-c445-d5cd-1922e1e40820@kernel.dk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------9291C5EC8B81DEC53F64DD54"
List-Id: <linux-ia64.vger.kernel.org>
References: <5fcc82b4-89ae-3bca-10ab-6ad933565cee@kernel.dk>
 <ae29ab73-ee7a-2bb7-3fd8-3037f40c1cbd@kernel.dk>
 <5611bde9-67e7-6ff6-defc-9b02ea830fac@physik.fu-berlin.de>
 <9ea14eb3-d698-5499-ba4c-c6a3c35cd8d4@kernel.dk>
 <47f79645-53b7-b11c-167a-f5721b53df02@physik.fu-berlin.de>
 <9d9acec6-1e8c-2d68-5dfa-d58c11cf5cc4@kernel.dk>
 <070780c4-445e-6373-c8f4-1c72d0f3b4e0@physik.fu-berlin.de>
 <1047f3e5-4599-c34f-3176-9f41d2e1246b@kernel.dk>
 <31b34cfc-8d6e-d3b4-e29f-1ec485f5b368@physik.fu-berlin.de>
In-Reply-To: <31b34cfc-8d6e-d3b4-e29f-1ec485f5b368@physik.fu-berlin.de>
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-sh@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

This is a multi-part message in MIME format.
--------------9291C5EC8B81DEC53F64DD54
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 1/1/21 7:06 AM, John Paul Adrian Glaubitz wrote:
> Hi Jens!
> 
> On 11/17/20 4:06 PM, Jens Axboe wrote:
>> On 11/16/20 10:26 PM, John Paul Adrian Glaubitz wrote:
>>> Hi Jens!
>>>
>>> On 11/9/20 3:14 PM, Jens Axboe wrote:
>>>>> Sorry for the delay. I'm busy at the moment and my SH board is currently
>>>>> building the Perl 5.32 package for Debian. Will try to test your patches
>>>>> by tomorrow, also ia64.
>>>>
>>>> Thanks, both would be appreciated! Just CC'ed you on the updated patch
>>>> for sh.
>>>
>>> Is this still relevant for testing? I'm ready to test now, much later than
>>> I thought, sorry.
>>>
>>> I'm going to build Linus' latest kernel for my SH and IA64 machines now
>>> and then I can test additional patches on top of it.
>>
>> Thanks, would definitely still appreciate testing. You can just run
>> linux-next if you want, it's got everything in there. Or apply the
>> separate patches to -git, either approach is fine.
> 
> Apologies for the late reply.
> 
> I just pulled Linus' latest tree today with your patch for SH included and
> I'm not seeing any regressions.
> 
> Is there away to test the change itself?

The only user of TWA_SIGNAL, which uses TIF_NOTIFY_SIGNAL, so far is io_uring.
You need something that triggers deferred task_work processing, which is
basically anything that ends up being poll driven for data/space readiness.
Here's a small test app from the liburing test suite, that'll trigger it.

If you install liburing, compile with:

gcc -Wall -O2 -o socket-rw socket-rw.c -luring

and run it without any arguments.

-- 
Jens Axboe


--------------9291C5EC8B81DEC53F64DD54
Content-Type: text/x-csrc; charset=UTF-8;
 name="socket-rw.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="socket-rw.c"

/* SPDX-License-Identifier: MIT */
/*
 * Check that a readv on a socket queued before a writev doesn't hang
 * the processing.
 *
 * From Hrvoje Zeba <zeba.hrvoje@gmail.com>
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>

#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <netinet/tcp.h>
#include <netinet/in.h>

#include <liburing.h>

int main(int argc, char *argv[])
{
	int p_fd[2], ret;
	int32_t recv_s0;
	int32_t val = 1;
	struct sockaddr_in addr;

	if (argc > 1)
		return 0;

	recv_s0 = socket(AF_INET, SOCK_STREAM | SOCK_CLOEXEC, IPPROTO_TCP);

	ret = setsockopt(recv_s0, SOL_SOCKET, SO_REUSEPORT, &val, sizeof(val));
	assert(ret != -1);
	ret = setsockopt(recv_s0, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val));
	assert(ret != -1);

	addr.sin_family = AF_INET;
	addr.sin_port = 0x1235;
	addr.sin_addr.s_addr = 0x0100007fU;

	ret = bind(recv_s0, (struct sockaddr*)&addr, sizeof(addr));
	assert(ret != -1);
	ret = listen(recv_s0, 128);
	assert(ret != -1);


	p_fd[1] = socket(AF_INET, SOCK_STREAM | SOCK_CLOEXEC, IPPROTO_TCP);

	val = 1;
	ret = setsockopt(p_fd[1], IPPROTO_TCP, TCP_NODELAY, &val, sizeof(val));
	assert(ret != -1);

	int32_t flags = fcntl(p_fd[1], F_GETFL, 0);
	assert(flags != -1);

	flags |= O_NONBLOCK;
	ret = fcntl(p_fd[1], F_SETFL, flags);
	assert(ret != -1);

	ret = connect(p_fd[1], (struct sockaddr*)&addr, sizeof(addr));
	assert(ret == -1);

	flags = fcntl(p_fd[1], F_GETFL, 0);
	assert(flags != -1);

	flags &= ~O_NONBLOCK;
	ret = fcntl(p_fd[1], F_SETFL, flags);
	assert(ret != -1);

	p_fd[0] = accept(recv_s0, NULL, NULL);
	assert(p_fd[0] != -1);

	while (1) {
		int32_t code;
		socklen_t code_len = sizeof(code);

		ret = getsockopt(p_fd[1], SOL_SOCKET, SO_ERROR, &code, &code_len);
		assert(ret != -1);

		if (!code)
			break;
	}

	struct io_uring m_io_uring;

	ret = io_uring_queue_init(32, &m_io_uring, 0);
	assert(ret >= 0);

	char recv_buff[128];
	char send_buff[128];

	{
		struct iovec iov[1];

		iov[0].iov_base = recv_buff;
		iov[0].iov_len = sizeof(recv_buff);

		struct io_uring_sqe* sqe = io_uring_get_sqe(&m_io_uring);
		assert(sqe != NULL);

		io_uring_prep_readv(sqe, p_fd[0], iov, 1, 0);
	}

	{
		struct iovec iov[1];

		iov[0].iov_base = send_buff;
		iov[0].iov_len = sizeof(send_buff);

		struct io_uring_sqe* sqe = io_uring_get_sqe(&m_io_uring);
		assert(sqe != NULL);

		io_uring_prep_writev(sqe, p_fd[1], iov, 1, 0);
	}

	ret = io_uring_submit_and_wait(&m_io_uring, 2);
	assert(ret != -1);

	struct io_uring_cqe* cqe;
	uint32_t head;
	uint32_t count = 0;

	while (count != 2) {
		io_uring_for_each_cqe(&m_io_uring, head, cqe) {
			assert(cqe->res == 128);
			count++;
		}

		assert(count <= 2);
		io_uring_cq_advance(&m_io_uring, count);
	}

	io_uring_queue_exit(&m_io_uring);
	return 0;
}

--------------9291C5EC8B81DEC53F64DD54--

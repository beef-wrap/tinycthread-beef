using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Interop;
using System.Text;

using static tinycthread.tinycthread;

namespace example;

static class Program
{
	/* This is the child thread function */
	public static int HelloThread(void* aArg)
	{
		Debug.WriteLine("Hello world!\n");
		return 0;
	}

	static int Main(params String[] args)
	{
		/* Start the child thread */
		thrd_t t = ?;

		if (thrd_create(&t, => HelloThread, (void*)0) == thrd_success)
		{
			/* Wait for the thread to finish */
			thrd_join(t, null);
		}

		return 0;
	}
}
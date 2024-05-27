import tkinter as tk
import aiohttp
import asyncio
import threading

def add_placeholder_to(entry, placeholder):
    entry.insert(0, placeholder)
    entry.config(fg = 'grey')

    def remove_placeholder(event):
        if entry.get() == placeholder:
            entry.delete(0, tk.END)
            entry.config(fg = 'black')

    def add_placeholder(event):
        if entry.get() == '':
            entry.insert(0, placeholder)
            entry.config(fg = 'grey')

    entry.bind('<FocusIn>', remove_placeholder)
    entry.bind('<FocusOut>', add_placeholder)

async def send_message(session, webhook_url, message, interval, stop_event):
    while not stop_event.is_set():
        data = {
            "content": message
        }

        async with session.post(webhook_url, data=data) as response:
            if response.status == 204:
                print(f"{webhook_url} へのメッセージが正常に送信されました。")
            else:
                print(f"{webhook_url} へのメッセージの送信に失敗しました。ステータスコード: {response.status}")

        # 指定された間隔で待機
        await asyncio.sleep(interval)

def start_sending_messages():
    global stop_event, task
    stop_event.clear()

    webhook_url = entry1.get()
    interval = float(entry2.get())
    message = entry3.get()

    async def main():
        async with aiohttp.ClientSession() as session:
            await send_message(session, webhook_url, message, interval, stop_event)

    # 非同期ループを開始
    task = threading.Thread(target=asyncio.run, args=(main(),))
    task.start()

def stop_sending_messages():
    global stop_event
    stop_event.set()

def main():
    # メインウィンドウを作成
    global root, entry1, entry2, entry3, stop_event, task
    root = tk.Tk()
    root.title("webhook spamp")
    root.geometry("600x450")
    root.configure(bg='gray')  # 背景色をグレーに設定

    stop_event = asyncio.Event()

    # 入力テキストボックスを作成
    entry1 = tk.Entry(root, font=('Helvetica', '30'))
    entry1.pack(pady=10)
    add_placeholder_to(entry1, 'webhookurl')

    entry2 = tk.Entry(root, font=('Helvetica', '30'))
    entry2.pack(pady=10)
    add_placeholder_to(entry2, '発言間隔【秒】')

    entry3 = tk.Entry(root, font=('Helvetica', '30'))
    entry3.pack(pady=10)
    add_placeholder_to(entry3, '発言するメッセージ')

    # スタートボタンとストップボタンを作成
    start_button = tk.Button(root, text="Start", width=20, height=2, font=('Helvetica', '20'), command=start_sending_messages)
    start_button.pack(side=tk.LEFT, padx=50, pady=20)

    stop_button = tk.Button(root, text="Stop", width=20, height=2, font=('Helvetica', '20'), command=stop_sending_messages)
    stop_button.pack(side=tk.RIGHT, padx=50, pady=20)

    # メインループを開始
    root.mainloop()

if __name__ == "__main__":
    main()

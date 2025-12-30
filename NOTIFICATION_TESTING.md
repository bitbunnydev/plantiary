## Testing Local Notifications

### Quick Test Steps:

1. **Test Immediate Notification (Instant)**
   - Open the app
   - Tap the notification bell icon (top-right on home screen)
   - Tap the test tube icon (🧪) in the top-right of Reminders screen
   - **You should see a notification immediately**
   - If not, check steps below

2. **Test Scheduled Notification (1 minute)**
   - Tap "Add Reminder" button
   - Fill in:
     - Title: "Test"
     - Description: "Testing notifications"
     - Type: Any
     - Date: Today
     - Time: **1 minute from now** (e.g., if it's 2:30 PM, set 2:31 PM)
   - Tap "Save Reminder"
   - Lock your phone or go to home screen
   - Wait 1 minute
   - **Notification should appear**

### Troubleshooting:

#### Android 13+ (Common Issue)
If you don't see notifications:

1. **Grant Notification Permission**
   - When app first launches, it should ask for notification permission
   - If you denied it, go to:
     - Settings → Apps → Plantiary → Notifications
     - Enable "Show notifications"

2. **Grant Exact Alarm Permission (Android 12+)**
   - Settings → Apps → Plantiary → Set alarms and reminders
   - Enable this permission

3. **Disable Battery Optimization**
   - Settings → Apps → Plantiary → Battery
   - Set to "Unrestricted"

4. **Check Do Not Disturb**
   - Make sure Do Not Disturb is OFF

#### Check Console Logs:
When you create a reminder, check the debug console for:
```
📅 Scheduling reminder: Test
⏰ Scheduled for: 2025-12-30 14:31:00.000
🆔 ID: 123456
🕐 Current time: 2025-12-30 14:30:00.000
🕑 Scheduled time: 2025-12-30 14:31:00.000
⏱️ Time difference: 60 seconds
✅ Notification scheduled successfully!
```

If you see `❌ Error scheduling notification`, share the error message.

### Common Issues:

**Issue**: "Test notification sent!" message appears but no notification
**Solution**: Check Android permissions (steps above)

**Issue**: Scheduled notification doesn't fire
**Solution**: 
- Make sure the time is in the future
- Check battery optimization
- Verify exact alarm permission

**Issue**: App crashes when adding reminder
**Solution**: Check debug console for errors related to timezone initialization

### Still Not Working?

Reply with:
1. Your Android version
2. Console output when creating a reminder
3. Whether the immediate test notification (🧪 button) works

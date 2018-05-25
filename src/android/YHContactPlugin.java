package com.contact.yhck;


import android.Manifest;
import android.content.ContentResolver;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;
import android.util.Log;
import android.widget.Toast;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.security.Permission;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class YHContactPlugin extends CordovaPlugin {
  private CallbackContext mCallbackContext;
  private int mContactsCount;
  private static final int GET_CONTACT_REQUESR_CODE = 0;
  public static final String[] CONTACTOR_ION = new String[]{
    ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
    ContactsContract.CommonDataKinds.Phone.NUMBER,
    ContactsContract.Contacts.DISPLAY_NAME,
  };

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    this.mCallbackContext = callbackContext;
    mContactsCount = 0;
    if (!"".equals(action) || action != null) {
      if ("getAllContactInfo".equals(action)) {
        readContacts();
      } else {
        getSelectContacts();
      }

      return true;
    }
    mCallbackContext.error("error");
    return false;
  }

  private void readContacts() {
    JSONObject jsonObject = new JSONObject();
    JSONArray jsonArray = new JSONArray();
    List<ContactsEntity> myContactList = new ArrayList<ContactsEntity>();
    //获取联系人信息的Uri
    Uri mUri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI;
    //获取ContentResolver
    ContentResolver contentResolver = cordova.getActivity().getContentResolver();
    //查询数据，返回Cursor
    Cursor cursor = contentResolver.query(mUri, CONTACTOR_ION, null, null, "sort_key");
    if (cursor != null) {
      while (cursor.moveToNext()) {
        ContactsEntity entity = new ContactsEntity();
        //获取联系人的姓名
        String name = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
        //获取联系人的电话
        String phoneNumber = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
        entity.setContactsName(name);
        entity.setContactsTEL(formatPhoneNum(phoneNumber));
        myContactList.add(entity);
      }
      try {
        if (myContactList.size() <= 0) {
          jsonObject.put("totalCount", 0);
          jsonObject.put("contacts", "");
        } else {
          for (ContactsEntity entity : myContactList) {
            JSONObject tmpObj = new JSONObject();
            tmpObj.put("contactsName", entity.getContactsName());
            tmpObj.put("contactsTel", entity.getContactsTEL());
            jsonArray.put(tmpObj);
          }
          jsonObject.put("totalCount", myContactList.size());
          jsonObject.put("contacts", jsonArray);
        }

      } catch (JSONException e) {
        e.printStackTrace();
      } finally {
        if (cursor != null) {
          cursor.close();
        }
      }

    }else{
      try {
        jsonObject.put("totalCount", -1);
        jsonObject.put("contacts", "");
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
    mCallbackContext.success(jsonObject);
  }

  private void getSelectContacts() {
    Intent intent = new Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI);
    cordova.startActivityForResult(this, intent, GET_CONTACT_REQUESR_CODE);
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    JSONObject jsonObject = new JSONObject();
    String usernumber = "";
    String username = "";
    if (requestCode == GET_CONTACT_REQUESR_CODE) {
      if (data != null) {
        ContentResolver mContentResolver = cordova.getActivity().getContentResolver();
        Uri contactData = data.getData();
        Cursor cursor = mContentResolver.query(contactData, CONTACTOR_ION, null, null, "sort_key");
        if (cursor != null) {
          try {
            while (cursor.moveToNext()) {
              username = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
              usernumber = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
            }
            jsonObject.put("grant", "1");
            jsonObject.put("name", username);
            jsonObject.put("phone", usernumber);
          } catch (JSONException e) {
            e.printStackTrace();
          } finally {
            if (cursor != null) {
              cursor.close();
            }
          }

        } else {
          try {
            jsonObject.put("grant", "0");
          } catch (JSONException e) {
            e.printStackTrace();
          }
        }
      } else {
        try {
          jsonObject.put("grant", "2");
          jsonObject.put("name", "");
          jsonObject.put("phone", "");
        } catch (JSONException e) {
          e.printStackTrace();
        }
      }
      mCallbackContext.success(jsonObject);
    }
  }

  /**
   * 联系人实体
   */
  public class ContactsEntity {
    private String ContactsTEL;//联系人电话
    private String ContactsName;//联系人姓名

    public String getContactsTEL() {
      return ContactsTEL;
    }

    public void setContactsTEL(String contactsTEL) {
      ContactsTEL = contactsTEL;
    }

    public String getContactsName() {
      return ContactsName;
    }

    public void setContactsName(String contactsName) {
      ContactsName = contactsName;
    }
  }

  /**
   * 去掉手机号内除数字外的所有字符
   *
   * @param phoneNum 手机号
   * @return
   */

  public String formatPhoneNum(String phoneNum) {
    String regex = "(\\+86)|[^0-9]";
    Pattern pattern = Pattern.compile(regex);
    Matcher matcher = pattern.matcher(phoneNum);
    return matcher.replaceAll("");
  }

}

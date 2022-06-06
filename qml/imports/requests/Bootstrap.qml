pragma Singleton

import QtQuick 2.0
import AsemanQml.Network 2.0
import AsemanQml.Base 2.0
import globals 1.0

BootstrapRequest {
    id: dis

    property alias tag: tag
    property alias trick: trick
    property alias user: user
    property alias signup: signup
    property alias timeline: timeline
    property alias agreement: agreement

    readonly property string title: { try { return features.title; } catch (e) { return qsTr("Tricks") + Translations.refresher; } }
    readonly property bool smartKeyboardHeight: { try { return features.smart_keyboard_height; } catch (e) { return true; } }
    readonly property bool dynamicKeyboardHeight: { try { return features.dynamic_keyboard_height; } catch (e) { return true; } }
    readonly property bool aseman: { try { return features.aseman; } catch (e) { return false; } }
    readonly property int defaultCommunity: { try { return features.default_community; } catch (e) { return 1; } }

    property variant limits
    property variant features
    property variant licenses

    onSmartKeyboardHeightChanged: GlobalSettings.smartKeyboardHeight = smartKeyboardHeight
    Component.onCompleted: {
        limits = Tools.jsonToVariant( Tools.readText(Constants.cacheLimits) );
        features = Tools.jsonToVariant( Tools.readText(Constants.cacheFeatures) );
        licenses = Tools.jsonToVariant( Tools.readText(Constants.cacheLicenses) );
        GlobalSettings.smartKeyboardHeight = smartKeyboardHeight;
    }

    onSuccessfull: {
        limits = response.result.limits;
        features = response.result.features;
        licenses = response.result.licenses;

        Tools.writeText(Constants.cacheLimits, Tools.variantToJson(limits));
        Tools.writeText(Constants.cacheFeatures, Tools.variantToJson(features));
        Tools.writeText(Constants.cacheLicenses, Tools.variantToJson(licenses));
    }

    QtObject {
        id: tag
        property int tag_max_length: { try { return limits.tag.tag_max_length; } catch (e) { return 2; } }
        property int tag_min_length: { try { return limits.tag.tag_min_length; } catch (e) { return 1; } }
    }

    QtObject {
        id: trick
        property int body_max_length: { try { return limits.trick.body_max_length; } catch (e) { return 255; } }
        property int body_min_length: { try { return limits.trick.body_min_length; } catch (e) { return 0; } }
        property int code_max_length: { try { return limits.trick.code_max_length; } catch (e) { return 1024; } }
        property int code_min_length: { try { return limits.trick.code_min_length; } catch (e) { return 1; } }
        property int tags_max_count: { try { return limits.trick.tags_max_count; } catch (e) { return 5; } }
        property int tags_min_count: { try { return limits.trick.tags_min_count; } catch (e) { return 0; } }
        property int allowed_edit_time: { try { return limits.trick.allowed_edit_time; } catch (e) { return 0; } }
        property int max_post_tricks: { try { return limits.trick.max_post_tricks; } catch (e) { return 0; } }
    }

    QtObject {
        id: user
        property int about_max_length: { try { return limits.user.about_max_length; } catch (e) { return 255; } }
        property int fullname_max_length: { try { return limits.user.fullname_max_length; } catch (e) { return 50; } }
        property int fullname_min_length: { try { return limits.user.fullname_min_length; } catch (e) { return 0; } }
        property int password_max_length: { try { return limits.user.password_max_length; } catch (e) { return 200; } }
        property int password_min_length: { try { return limits.user.password_min_length; } catch (e) { return 5; } }
        property int username_max_length: { try { return limits.user.username_max_length; } catch (e) { return 20; } }
        property int username_min_length: { try { return limits.user.username_min_length; } catch (e) { return 3; } }
    }

    QtObject {
        id: signup
        property bool invitation_code: { try { return features.signup.invitation_code; } catch (e) { return false; } }
    }

    QtObject {
        id: timeline
        property bool unauth_timeline: { try { return features.timeline.unauth_timeline; } catch (e) { return false; } }
    }

    QtObject {
        id: agreement
        property string markdown: { try { return licenses.agreement.markdown; } catch (e) { return ""; } }
        property string plain: { try { return licenses.agreement.plain; } catch (e) { return ""; } }
        property int version: { try { return licenses.agreement.version; } catch (e) { return 0; } }
    }

    function init() { doRequest() }
}
